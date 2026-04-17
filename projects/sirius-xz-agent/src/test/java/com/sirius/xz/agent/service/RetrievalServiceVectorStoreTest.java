package com.sirius.xz.agent.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.InMemoryChunkVectorStore;
import com.sirius.xz.agent.persistence.KnowledgeChunkRow;
import java.util.List;
import org.junit.jupiter.api.Test;

class RetrievalServiceVectorStoreTest {

    public static void main(String[] args) {
        new RetrievalServiceVectorStoreTest().searchPrefersVectorHitsOverFallback();
    }

    @Test
    void searchPrefersVectorHitsOverFallback() {
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument("spring-ai", "Spring AI", "Spring AI integrates models.", List.of("spring")),
            new KnowledgeDocument("rag-playbook", "RAG Playbook", "RAG keeps answers grounded.", List.of("rag"))
        ));

        InMemoryChunkVectorStore vectorStore = new InMemoryChunkVectorStore();
        vectorStore.save(new KnowledgeChunkRow(
            "rag-playbook",
            "RAG Playbook",
            0,
            "RAG keeps answers grounded.",
            List.of("rag"),
            new DeterministicEmbeddingService(8).embed("RAG keeps answers grounded.")
        ));
        vectorStore.save(new KnowledgeChunkRow(
            "spring-ai",
            "Spring AI",
            0,
            "Spring AI integrates models.",
            List.of("spring"),
            new DeterministicEmbeddingService(8).embed("Spring AI integrates models.")
        ));

        RetrievalService service = new RetrievalService(
            knowledgeBase,
            vectorStore,
            new DeterministicEmbeddingService(8)
        );

        List<KnowledgeSearchResult> results = service.search("How does RAG keep answers grounded?", 1);

        assertThat(results).hasSize(1);
        assertThat(results.get(0).document().title()).isEqualTo("RAG Playbook");
        assertThat(results.get(0).document().content()).contains("grounded");
    }
}
