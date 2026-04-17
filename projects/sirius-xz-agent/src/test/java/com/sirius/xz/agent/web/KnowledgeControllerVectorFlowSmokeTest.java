package com.sirius.xz.agent.web;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.config.RagInfrastructureConfiguration;
import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.PgVectorStore;
import com.sirius.xz.agent.service.AgentService;
import com.sirius.xz.agent.service.ChunkingService;
import com.sirius.xz.agent.service.DeterministicEmbeddingService;
import com.sirius.xz.agent.service.InMemoryKnowledgeBase;
import com.sirius.xz.agent.service.KnowledgeIngestionService;
import com.sirius.xz.agent.service.RetrievalService;
import java.util.List;
import org.junit.jupiter.api.Test;

class KnowledgeControllerVectorFlowSmokeTest {

    public static void main(String[] args) {
        new KnowledgeControllerVectorFlowSmokeTest().upsertThenAskUsesVectorRecall();
    }

    @Test
    void upsertThenAskUsesVectorRecall() {
        RagInfrastructureConfiguration configuration = new RagInfrastructureConfiguration();
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of());
        PgVectorStore vectorStore = configuration.pgVectorStore();
        DeterministicEmbeddingService embeddingService = new DeterministicEmbeddingService(8);
        KnowledgeIngestionService ingestionService = new KnowledgeIngestionService(
            knowledgeBase,
            configuration.chunkingService(),
            embeddingService,
            vectorStore
        );

        KnowledgeController knowledgeController = new KnowledgeController(knowledgeBase, ingestionService);
        AgentService agentService = new AgentService(new RetrievalService(knowledgeBase, vectorStore, embeddingService));
        AgentController agentController = new AgentController(agentService);

        KnowledgeDocument created = knowledgeController.upsert(new KnowledgeController.KnowledgeDocumentRequest(
            "rag-playbook",
            "RAG Playbook",
            "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
            List.of("rag", "knowledge")
        ));

        assertThat(created.id()).isEqualTo("rag-playbook");
        assertThat(knowledgeController.documents()).hasSize(1);
        assertThat(agentController.ask("How does RAG keep answers grounded?").answer()).contains("RAG Playbook");
    }
}
