package com.sirius.xz.agent.persistence;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class InMemoryChunkVectorStoreTest {

    public static void main(String[] args) {
        new InMemoryChunkVectorStoreTest().searchRanksHighestSimilarityFirst();
    }

    @Test
    void searchRanksHighestSimilarityFirst() {
        InMemoryChunkVectorStore store = new InMemoryChunkVectorStore();
        store.save(new KnowledgeChunkRow("doc-1", "RAG Playbook", 0, "retrieval grounded", List.of("rag"), new float[] {1.0f, 0.0f, 0.0f}));
        store.save(new KnowledgeChunkRow("doc-2", "Spring AI", 0, "model integration", List.of("spring"), new float[] {0.0f, 1.0f, 0.0f}));

        List<ChunkSearchResult> results = store.search(new float[] {1.0f, 0.0f, 0.0f}, 1);

        assertThat(results).hasSize(1);
        assertThat(results.get(0).documentId()).isEqualTo("doc-1");
    }
}
