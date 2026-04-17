package com.sirius.xz.agent.domain;

import java.util.List;

public record KnowledgeDocument(
    String id,
    String title,
    String content,
    List<String> tags
) {
    public String searchableText() {
        return String.join(" ", id, title, content, String.join(" ", tags));
    }
}

