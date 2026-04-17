package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import org.springframework.stereotype.Component;

@Component
public class InMemoryKnowledgeBase implements KnowledgeBase {

    private final CopyOnWriteArrayList<KnowledgeDocument> documents = new CopyOnWriteArrayList<>();

    public InMemoryKnowledgeBase() {
        this(List.of(
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
                "vibe-coding",
                "Vibe Coding",
                "Vibe coding improves productivity with AI-assisted workflows and rapid iteration.",
                List.of("productivity", "ai")
            )
        ));
    }

    public InMemoryKnowledgeBase(List<KnowledgeDocument> seedDocuments) {
        documents.addAll(List.copyOf(Objects.requireNonNull(seedDocuments, "seedDocuments must not be null")));
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

    @Override
    public Optional<KnowledgeDocument> findById(String id) {
        return documents.stream()
            .filter(document -> document.id().equals(id))
            .findFirst();
    }
}
