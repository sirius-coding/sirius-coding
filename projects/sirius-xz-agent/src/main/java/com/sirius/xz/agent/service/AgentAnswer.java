package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public record AgentAnswer(
    String answer,
    List<KnowledgeDocument> sources,
    int confidence,
    List<String> matchedTokens
) {
    public String summary() {
        return answer;
    }
}
