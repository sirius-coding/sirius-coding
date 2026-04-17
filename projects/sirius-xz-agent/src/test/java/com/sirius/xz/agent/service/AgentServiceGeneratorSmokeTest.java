package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public final class AgentServiceGeneratorSmokeTest {

    private AgentServiceGeneratorSmokeTest() {
    }

    public static void main(String[] args) {
        KnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument(
                "rag-playbook",
                "RAG Playbook",
                "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
                List.of("rag", "knowledge")
            )
        ));

        AgentService service = new AgentService(new RetrievalService(knowledgeBase), (question, results) ->
            "LLM: " + question + " / " + results.get(0).document().title()
        );

        AgentAnswer answer = service.answer("How does RAG keep answers grounded?");
        if (!answer.summary().contains("LLM: How does RAG keep answers grounded? / RAG Playbook")) {
            throw new IllegalStateException("Expected configured generator to be used");
        }
    }
}
