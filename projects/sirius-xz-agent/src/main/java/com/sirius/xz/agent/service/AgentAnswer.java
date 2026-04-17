package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public record AgentAnswer(
    String summary,
    List<KnowledgeDocument> sources
) {
}

