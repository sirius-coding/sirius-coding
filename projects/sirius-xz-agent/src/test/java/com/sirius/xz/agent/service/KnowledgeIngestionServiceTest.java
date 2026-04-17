package com.sirius.xz.agent.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.InMemoryChunkVectorStore;
import com.sirius.xz.agent.persistence.ChunkSearchResult;
import java.util.List;
import org.junit.jupiter.api.Test;

class KnowledgeIngestionServiceTest {

    public static void main(String[] args) {
        new KnowledgeIngestionServiceTest().upsertStoresChunkVectorsAndReplacesOldContent();
    }

    @Test
    void upsertStoresChunkVectorsAndReplacesOldContent() {
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of());
        InMemoryChunkVectorStore vectorStore = new InMemoryChunkVectorStore();
        KnowledgeIngestionService service = new KnowledgeIngestionService(
            knowledgeBase,
            new ChunkingService(24),
            new DeterministicEmbeddingService(8),
            vectorStore
        );

        service.upsert(new KnowledgeDocument("doc-1", "RAG Playbook", "alpha beta gamma delta epsilon zeta", List.of("rag")));
        service.upsert(new KnowledgeDocument("doc-1", "RAG Playbook", "theta iota kappa lambda mu nu", List.of("rag")));

        assertThat(knowledgeBase.findById("doc-1")).isPresent();
        List<ChunkSearchResult> hits = vectorStore.search(new DeterministicEmbeddingService(8).embed("theta iota"), 10);
        assertThat(hits).isNotEmpty();
        assertThat(hits.get(0).chunkText()).contains("theta");
    }
}
