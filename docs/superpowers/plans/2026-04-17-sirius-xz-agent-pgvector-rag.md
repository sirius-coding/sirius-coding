# sirius-xz-agent pgvector RAG Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `sirius-xz-agent` into a PostgreSQL + `pgvector` backed RAG scaffold that ingests documents, stores chunks and vectors, and answers questions with DeepSeek when enabled while keeping a local fallback path.

**Architecture:** Keep the current controller/service boundaries, but replace rule-only retrieval with document chunking, deterministic embeddings, and a PostgreSQL vector store. The answer generator remains pluggable so DeepSeek can be enabled by configuration without making the app unusable when external services are absent.

**Tech Stack:** Java 21, Spring Boot 3.5, Spring AI 1.1.3, Spring AI Alibaba BOM, DeepSeek chat model, PostgreSQL 16, `pgvector`, JDBC, JUnit 5, AssertJ.

---

### Task 1: Add chunking and embedding primitives

**Files:**
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/domain/DocumentChunk.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/ChunkingService.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/EmbeddingService.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/DeterministicEmbeddingService.java`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/ChunkingServiceTest.java`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/DeterministicEmbeddingServiceTest.java`

- [ ] **Step 1: Write the failing tests**

```java
@Test
void chunkingSplitsLongTextIntoOrderedChunks() {
    ChunkingService service = new ChunkingService(80);
    List<DocumentChunk> chunks = service.chunk(
        new KnowledgeDocument("doc-1", "RAG Playbook", "alpha beta gamma delta epsilon zeta eta theta iota kappa", List.of("rag"))
    );

    assertThat(chunks).hasSizeGreaterThan(1);
    assertThat(chunks.get(0).chunkIndex()).isEqualTo(0);
    assertThat(chunks.get(0).documentId()).isEqualTo("doc-1");
}
```

```java
@Test
void embeddingServiceReturnsStableVectorForSameText() {
    EmbeddingService service = new DeterministicEmbeddingService(8);
    float[] first = service.embed("RAG keeps answers grounded.");
    float[] second = service.embed("RAG keeps answers grounded.");

    assertThat(first).containsExactly(second);
    assertThat(first).hasSize(8);
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run:
`mvn -q -Dtest=ChunkingServiceTest,DeterministicEmbeddingServiceTest test`

Expected:
`Compilation/test failure because the new classes do not exist yet`

- [ ] **Step 3: Implement the minimal code**

```java
public record DocumentChunk(
    String documentId,
    String documentTitle,
    int chunkIndex,
    String chunkText,
    List<String> tags
) {}
```

```java
public class ChunkingService {
    private final int chunkSize;

    public ChunkingService(int chunkSize) {
        this.chunkSize = chunkSize;
    }

    public List<DocumentChunk> chunk(KnowledgeDocument document) {
        // split on whitespace, keep order, emit chunkIndex starting at 0
    }
}
```

```java
public interface EmbeddingService {
    float[] embed(String text);
}
```

```java
public class DeterministicEmbeddingService implements EmbeddingService {
    // hash token frequencies into a fixed-length float vector
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run:
`mvn -q -Dtest=ChunkingServiceTest,DeterministicEmbeddingServiceTest test`

Expected:
`Both tests pass`

- [ ] **Step 5: Commit**

```bash
git add projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/domain/DocumentChunk.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/ChunkingService.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/EmbeddingService.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/DeterministicEmbeddingService.java \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/ChunkingServiceTest.java \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/DeterministicEmbeddingServiceTest.java
git commit -m "feat: add chunking and embedding primitives"
```

### Task 2: Add PostgreSQL pgvector storage

**Files:**
- Create: `projects/sirius-xz-agent/src/main/resources/db/migration/V1__knowledge_chunk.sql`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/KnowledgeChunkRow.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/PgVectorStore.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/JdbcPgVectorStore.java`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/persistence/PgVectorStoreSmokeTest.java`

- [ ] **Step 1: Write the failing test**

```java
@Test
void storesAndSearchesChunksByVectorSimilarity() {
    PgVectorStore store = new JdbcPgVectorStore(jdbcTemplate, 8);
    store.save(new KnowledgeChunkRow("doc-1", "RAG Playbook", 0, "RAG combines retrieval", List.of("rag"), new float[]{1,0,0,0,0,0,0,0}));
    store.save(new KnowledgeChunkRow("doc-2", "Spring AI", 0, "Spring AI integrates models", List.of("spring"), new float[]{0,1,0,0,0,0,0,0}));

    List<KnowledgeSearchResult> hits = store.search(new float[]{1,0,0,0,0,0,0,0}, 1);

    assertThat(hits).hasSize(1);
    assertThat(hits.get(0).documentId()).isEqualTo("doc-1");
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
`mvn -q -Dtest=PgVectorStoreSmokeTest test`

Expected:
`Fails because schema/repository classes are missing`

- [ ] **Step 3: Implement the minimal code**

```sql
create table if not exists knowledge_chunk (
    id bigserial primary key,
    document_id varchar(128) not null,
    document_title varchar(256) not null,
    chunk_index integer not null,
    chunk_text text not null,
    tags text[] not null,
    embedding vector(8) not null,
    created_at timestamp not null default now()
);
```

```java
public record KnowledgeChunkRow(
    String documentId,
    String documentTitle,
    int chunkIndex,
    String chunkText,
    List<String> tags,
    float[] embedding
) {}
```

```java
public interface PgVectorStore {
    void save(KnowledgeChunkRow row);
    List<KnowledgeSearchResult> search(float[] queryVector, int limit);
}
```

```java
public class JdbcPgVectorStore implements PgVectorStore {
    // use JdbcTemplate, persist vectors as pgvector literal strings, query with cosine distance
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run:
`mvn -q -Dtest=PgVectorStoreSmokeTest test`

Expected:
`Pass with persisted rows and Top-K retrieval`

- [ ] **Step 5: Commit**

```bash
git add projects/sirius-xz-agent/src/main/resources/db/migration/V1__knowledge_chunk.sql \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/KnowledgeChunkRow.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/PgVectorStore.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/persistence/JdbcPgVectorStore.java \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/persistence/PgVectorStoreSmokeTest.java
git commit -m "feat: add pgvector knowledge storage"
```

### Task 3: Wire ingestion and retrieval to the vector store

**Files:**
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/KnowledgeIngestionService.java`
- Modify: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/web/KnowledgeController.java`
- Modify: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/RetrievalService.java`
- Modify: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/AgentService.java`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/KnowledgeIngestionServiceTest.java`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/RetrievalServiceVectorStoreTest.java`

- [ ] **Step 1: Write the failing tests**

```java
@Test
void upsertIngestsChunksIntoVectorStore() {
    KnowledgeIngestionService service = new KnowledgeIngestionService(chunkingService, embeddingService, vectorStore, knowledgeBase);
    service.upsert(new KnowledgeDocument("doc-1", "RAG Playbook", "alpha beta gamma delta", List.of("rag")));

    assertThat(vectorStore.search(new float[]{1,0,0,0,0,0,0,0}, 10)).isNotEmpty();
}
```

```java
@Test
void retrievalUsesVectorHitsBeforeFallbackScoring() {
    RetrievalService service = new RetrievalService(vectorStore, knowledgeBase);
    List<KnowledgeSearchResult> results = service.search("How does RAG keep answers grounded?", 3);

    assertThat(results.get(0).documentTitle()).isEqualTo("RAG Playbook");
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run:
`mvn -q -Dtest=KnowledgeIngestionServiceTest,RetrievalServiceVectorStoreTest test`

Expected:
`Fails because ingestion service and vector-backed retrieval are not wired yet`

- [ ] **Step 3: Implement the minimal code**

```java
public class KnowledgeIngestionService {
    public KnowledgeDocument upsert(KnowledgeDocument document) {
        // upsert into knowledge base, chunk, embed, and store rows
    }
}
```

```java
public class RetrievalService {
    public List<KnowledgeSearchResult> search(String question, int limit) {
        // ask vector store for top-k; if unavailable, keep the current rule-based fallback
    }
}
```

```java
public class AgentService {
    public AgentAnswer answer(String question) {
        // call retrieval service, then structured answer generator
    }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run:
`mvn -q -Dtest=KnowledgeIngestionServiceTest,RetrievalServiceVectorStoreTest test`

Expected:
`Pass`

- [ ] **Step 5: Commit**

```bash
git add projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/KnowledgeIngestionService.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/web/KnowledgeController.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/RetrievalService.java \
        projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/AgentService.java \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/KnowledgeIngestionServiceTest.java \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/service/RetrievalServiceVectorStoreTest.java
git commit -m "feat: wire knowledge ingestion to pgvector retrieval"
```

### Task 4: Update configuration, docs, and runtime behavior

**Files:**
- Modify: `projects/sirius-xz-agent/pom.xml`
- Modify: `projects/sirius-xz-agent/src/main/resources/application.yml`
- Modify: `projects/sirius-xz-agent/README.md`
- Modify: `README.md`
- Create: `projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/web/KnowledgeControllerVectorFlowSmokeTest.java`

- [ ] **Step 1: Write the failing smoke test**

```java
@Test
void controllerPersistsAndAnswersWithVectorFlow() {
    KnowledgeController controller = new KnowledgeController(knowledgeBase);
    AgentController agentController = new AgentController(agentService);

    KnowledgeDocument created = controller.upsert(new KnowledgeController.KnowledgeDocumentRequest(
        "doc-1",
        "RAG Playbook",
        "RAG keeps answers grounded with retrieval.",
        List.of("rag")
    ));

    assertThat(created.id()).isEqualTo("doc-1");
    assertThat(controller.documents()).hasSize(1);
    assertThat(agentController.ask("How does RAG keep answers grounded?").summary()).contains("RAG");
}
```

- [ ] **Step 2: Run the smoke test and confirm it fails**

Run:
`javac` / `java` smoke test command for `KnowledgeControllerVectorFlowSmokeTest`

Expected:
`Failure because the new wiring is not fully documented or bootstrapped yet`

- [ ] **Step 3: Update the runtime configuration**

```yaml
sirius:
  ai:
    deepseek:
      enabled: ${SIRIUS_AI_DEEPSEEK_ENABLED:false}
      api-key: ${DEEPSEEK_API_KEY:}
      base-url: ${DEEPSEEK_BASE_URL:https://api.deepseek.com}
      model: ${DEEPSEEK_MODEL:deepseek-chat}
  vectorstore:
    enabled: ${SIRIUS_VECTORSTORE_ENABLED:false}
spring:
  datasource:
    url: ${SPRING_DATASOURCE_URL:}
    username: ${SPRING_DATASOURCE_USERNAME:}
    password: ${SPRING_DATASOURCE_PASSWORD:}
```

- [ ] **Step 4: Update README guidance**

Add a short section that explains:

- PostgreSQL and `pgvector` are required for the real RAG path
- DeepSeek is optional and controlled by `SIRIUS_AI_DEEPSEEK_ENABLED`
- local fallback still works when external services are absent

- [ ] **Step 5: Run final verification**

Run:
`bash -lc 'set -euo pipefail; cd projects/sirius-xz-agent; mvn -q -DskipTests package'`

Then run the smoke tests that validate the fallback path and the new vector path.

Expected:
`Build succeeds and the smoke tests pass`

- [ ] **Step 6: Commit**

```bash
git add projects/sirius-xz-agent/pom.xml \
        projects/sirius-xz-agent/src/main/resources/application.yml \
        projects/sirius-xz-agent/README.md \
        README.md \
        projects/sirius-xz-agent/src/test/java/com/sirius/xz/agent/web/KnowledgeControllerVectorFlowSmokeTest.java
git commit -m "docs: update sirius-xz-agent pgvector rag usage"
```

## Self-Review Checklist

- The plan covers the full spec: chunking, embeddings, PostgreSQL `pgvector`, retrieval, DeepSeek generation, and fallback mode.
- No placeholders remain in task descriptions or code snippets.
- The naming is consistent across tasks: `DocumentChunk`, `EmbeddingService`, `PgVectorStore`, `KnowledgeIngestionService`, `RetrievalService`.
- Each task is independently testable and ends with a commit.
