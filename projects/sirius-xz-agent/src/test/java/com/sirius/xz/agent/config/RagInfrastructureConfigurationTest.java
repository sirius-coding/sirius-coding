package com.sirius.xz.agent.config;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.persistence.InMemoryChunkVectorStore;
import com.sirius.xz.agent.persistence.PgVectorStore;
import com.sirius.xz.agent.service.ChunkingService;
import com.sirius.xz.agent.service.DeterministicEmbeddingService;
import com.sirius.xz.agent.service.EmbeddingService;
import org.junit.jupiter.api.Test;

class RagInfrastructureConfigurationTest {

    public static void main(String[] args) {
        RagInfrastructureConfiguration configuration = new RagInfrastructureConfiguration();
        assertThat(configuration.chunkingService()).isInstanceOf(ChunkingService.class);
        assertThat(configuration.embeddingService()).isInstanceOf(EmbeddingService.class);
        assertThat(configuration.pgVectorStore()).isInstanceOf(InMemoryChunkVectorStore.class);
    }

    @Test
    void defaultFallbackBeansAreLocalAndDeterministic() {
        RagInfrastructureConfiguration configuration = new RagInfrastructureConfiguration();

        assertThat(configuration.chunkingService()).isInstanceOf(ChunkingService.class);
        assertThat(configuration.embeddingService()).isInstanceOf(DeterministicEmbeddingService.class);
        PgVectorStore store = configuration.pgVectorStore();
        assertThat(store).isInstanceOf(InMemoryChunkVectorStore.class);
    }
}
