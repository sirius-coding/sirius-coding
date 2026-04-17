package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public final class RetrievalServiceSmokeTest {

    private RetrievalServiceSmokeTest() {
    }

    public static void main(String[] args) {
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument(
                "spring-ai",
                "Spring AI",
                "Spring AI integrates large language models with Spring applications.",
                List.of("spring", "ai")
            ),
            new KnowledgeDocument(
                "rag-playbook",
                "RAG Playbook",
                "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
                List.of("rag", "knowledge")
            ),
            new KnowledgeDocument(
                "tooling",
                "Tooling",
                "Tool calling and orchestration are important for agentic systems.",
                List.of("agent", "tools")
            )
        ));

        RetrievalService retrievalService = new RetrievalService(knowledgeBase);
        List<KnowledgeSearchResult> results = retrievalService.search("How does RAG keep answers grounded?", 2);

        if (results.isEmpty()) {
            throw new IllegalStateException("Expected at least one retrieval result");
        }

        if (!"rag-playbook".equals(results.get(0).document().id())) {
            throw new IllegalStateException("Expected RAG Playbook to rank first, got " + results.get(0).document().id());
        }

        if (results.get(0).score() <= 0) {
            throw new IllegalStateException("Expected positive score for the top result");
        }
    }
}

