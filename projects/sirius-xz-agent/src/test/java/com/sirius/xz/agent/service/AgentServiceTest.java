package com.sirius.xz.agent.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class AgentServiceTest {

    @Test
    void answerUsesTheMostRelevantKnowledgeDocument() {
        KnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
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
            )
        ));

        AgentService service = new AgentService(knowledgeBase);

        AgentAnswer answer = service.answer("How does RAG keep answers grounded?");

        assertThat(answer.summary()).contains("RAG");
        assertThat(answer.sources()).extracting(KnowledgeDocument::title)
            .containsExactly("RAG Playbook");
    }
}

