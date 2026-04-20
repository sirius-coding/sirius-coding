package com.sirius.xz.agent.integration;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.JdbcPgVectorStore;
import com.sirius.xz.agent.service.ChunkingService;
import com.sirius.xz.agent.service.DeterministicEmbeddingService;
import com.sirius.xz.agent.service.InMemoryKnowledgeBase;
import com.sirius.xz.agent.service.KnowledgeBase;
import com.sirius.xz.agent.service.KnowledgeIngestionService;
import com.sirius.xz.agent.service.KnowledgeSearchResult;
import com.sirius.xz.agent.service.RetrievalService;
import java.util.List;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

class CloudPgVectorIntegrationTest {

    @Test
    void realPgVectorSearchWorksThroughJdbc() {
        Assumptions.assumeTrue(Boolean.parseBoolean(System.getenv().getOrDefault("SIRIUS_CLOUD_IT_ENABLED", "false")));

        String port = System.getenv().getOrDefault("SIRIUS_CLOUD_IT_PORT", "15432");
        DriverManagerDataSource dataSource = new DriverManagerDataSource(
            "jdbc:postgresql://127.0.0.1:" + port + "/sirius_xz_agent",
            System.getenv().getOrDefault("SIRIUS_CLOUD_IT_USERNAME", "sirius"),
            System.getenv().getOrDefault("SIRIUS_CLOUD_IT_PASSWORD", "sirius")
        );
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.execute("delete from knowledge_chunk");

        KnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of());
        JdbcPgVectorStore vectorStore = new JdbcPgVectorStore(jdbcTemplate);
        DeterministicEmbeddingService embeddingService = new DeterministicEmbeddingService(8);
        KnowledgeIngestionService ingestionService = new KnowledgeIngestionService(
            knowledgeBase,
            new ChunkingService(32),
            embeddingService,
            vectorStore
        );
        RetrievalService retrievalService = new RetrievalService(knowledgeBase, vectorStore, embeddingService);

        ingestionService.upsert(new KnowledgeDocument(
            "rag-playbook",
            "RAG Playbook",
            "RAG grounds answers with retrieval before generation and keeps model output tied to internal knowledge.",
            List.of("rag", "retrieval")
        ));
        ingestionService.upsert(new KnowledgeDocument(
            "spring-ai",
            "Spring AI",
            "Spring AI helps integrate chat models and embeddings into Java applications.",
            List.of("spring", "ai")
        ));

        List<KnowledgeSearchResult> results = retrievalService.search("How does retrieval keep RAG grounded?", 2);

        assertThat(results).isNotEmpty();
        assertThat(results.get(0).document().id()).isEqualTo("rag-playbook");
        assertThat(results.get(0).score()).isGreaterThan(0);
        assertThat(results.get(0).matchedTokens()).contains("rag");
    }
}
