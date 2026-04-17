package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public record KnowledgeSearchResult(
    KnowledgeDocument document,
    int score,
    List<String> matchedTokens
) {
}
