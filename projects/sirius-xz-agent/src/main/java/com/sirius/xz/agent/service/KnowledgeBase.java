package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public interface KnowledgeBase {

    List<KnowledgeDocument> documents();

    void upsert(KnowledgeDocument document);
}

