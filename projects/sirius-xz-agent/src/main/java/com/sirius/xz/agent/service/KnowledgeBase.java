package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import java.util.Optional;

public interface KnowledgeBase {

    List<KnowledgeDocument> documents();

    void upsert(KnowledgeDocument document);

    Optional<KnowledgeDocument> findById(String id);
}
