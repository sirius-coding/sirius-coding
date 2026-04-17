package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public final class AgentWorkflowSmokeTest {

    private AgentWorkflowSmokeTest() {
    }

    public static void main(String[] args) {
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument(
                "rag-playbook",
                "RAG Playbook",
                "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
                List.of("rag", "knowledge")
            ),
            new KnowledgeDocument(
                "vibe-coding",
                "Vibe Coding",
                "Vibe coding improves productivity with AI-assisted workflows and rapid iteration.",
                List.of("productivity", "ai")
            )
        ));

        AgentService service = new AgentService(knowledgeBase);
        AgentAnswer answer = service.answer("How does RAG keep answers grounded?");

        if (!answer.answer().contains("RAG Playbook")) {
            throw new IllegalStateException("Expected answer to cite the RAG Playbook");
        }

        if (answer.sources().isEmpty()) {
            throw new IllegalStateException("Expected sources to be returned");
        }
    }
}

