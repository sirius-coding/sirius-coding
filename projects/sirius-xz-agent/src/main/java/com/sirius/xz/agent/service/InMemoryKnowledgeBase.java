package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import org.springframework.stereotype.Component;

@Component
public class InMemoryKnowledgeBase implements KnowledgeBase {

    private final CopyOnWriteArrayList<KnowledgeDocument> documents = new CopyOnWriteArrayList<>();

    public InMemoryKnowledgeBase() {
        documents.add(new KnowledgeDocument(
            "spring-ai",
            "Spring AI",
            "Spring AI integrates large language models with Spring applications.",
            List.of("spring", "ai")
        ));
        documents.add(new KnowledgeDocument(
            "rag-playbook",
            "RAG Playbook",
            "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
            List.of("rag", "knowledge")
        ));
        documents.add(new KnowledgeDocument(
            "vibe-coding",
            "Vibe Coding",
            "Vibe coding improves productivity with AI-assisted workflows and rapid iteration.",
            List.of("productivity", "ai")
        ));
    }

    @Override
    public List<KnowledgeDocument> documents() {
        return List.copyOf(documents);
    }

    @Override
    public void upsert(KnowledgeDocument document) {
        documents.removeIf(existing -> existing.id().equals(document.id()));
        documents.add(document);
    }
}

