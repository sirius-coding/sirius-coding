package com.sirius.xz.agent.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class DeterministicEmbeddingServiceTest {

    public static void main(String[] args) {
        new DeterministicEmbeddingServiceTest().embeddingServiceReturnsStableVectorForSameText();
    }

    @Test
    void embeddingServiceReturnsStableVectorForSameText() {
        EmbeddingService service = new DeterministicEmbeddingService(8);

        float[] first = service.embed("RAG keeps answers grounded.");
        float[] second = service.embed("RAG keeps answers grounded.");

        assertThat(first).hasSize(8);
        assertThat(second).hasSize(8);
        assertThat(first).containsExactly(second);
    }
}
