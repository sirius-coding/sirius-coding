package com.sirius.xz.agent.service;

import java.util.List;

public final class AgentSmokeTest {

    private AgentSmokeTest() {
    }

    public static void main(String[] args) {
        KnowledgeBase knowledgeBase = new InMemoryKnowledgeBase();
        AgentService service = new AgentService(knowledgeBase);

        AgentAnswer answer = service.answer("How does RAG keep answers grounded?");

        if (!answer.summary().contains("RAG")) {
            throw new IllegalStateException("Expected answer summary to mention RAG");
        }
        List<String> titles = answer.sources().stream().map(document -> document.title()).toList();
        if (!titles.equals(List.of("RAG Playbook"))) {
            throw new IllegalStateException("Expected the RAG Playbook document to be the top source, got " + titles);
        }
    }
}

