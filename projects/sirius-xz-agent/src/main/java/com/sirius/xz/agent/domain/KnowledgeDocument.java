package com.sirius.xz.agent.domain;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public record KnowledgeDocument(
    String id,
    String title,
    String content,
    List<String> tags
) {
    public KnowledgeDocument {
        id = Objects.requireNonNull(id, "id must not be null");
        title = Objects.requireNonNull(title, "title must not be null");
        content = Objects.requireNonNull(content, "content must not be null");
        tags = List.copyOf(new ArrayList<>(Objects.requireNonNull(tags, "tags must not be null")));
    }

    public String searchableText() {
        return String.join(" ", id, title, content, String.join(" ", tags));
    }
}
