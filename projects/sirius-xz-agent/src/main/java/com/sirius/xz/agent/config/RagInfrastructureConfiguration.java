package com.sirius.xz.agent.config;

import com.sirius.xz.agent.persistence.InMemoryChunkVectorStore;
import com.sirius.xz.agent.persistence.PgVectorStore;
import com.sirius.xz.agent.service.ChunkingService;
import com.sirius.xz.agent.service.DeterministicEmbeddingService;
import com.sirius.xz.agent.service.EmbeddingService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
public class RagInfrastructureConfiguration {

    @Bean
    public ChunkingService chunkingService() {
        return new ChunkingService(240);
    }

    @Bean
    public EmbeddingService embeddingService() {
        return new DeterministicEmbeddingService(8);
    }

    @Bean
    public PgVectorStore pgVectorStore() {
        return new InMemoryChunkVectorStore();
    }
}
