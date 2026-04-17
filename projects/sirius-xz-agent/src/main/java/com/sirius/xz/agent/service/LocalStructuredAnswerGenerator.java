package com.sirius.xz.agent.service;

import java.util.List;

public class LocalStructuredAnswerGenerator implements StructuredAnswerGenerator {

    public LocalStructuredAnswerGenerator() {
    }

    @Override
    public String generate(String question, List<KnowledgeSearchResult> results) {
        KnowledgeSearchResult bestMatch = results.get(0);
        StringBuilder builder = new StringBuilder();
        builder.append("问题：").append(question).append('\n');
        builder.append("回答：基于知识库，最相关的资料是《")
            .append(bestMatch.document().title())
            .append("》。")
            .append('\n');
        builder.append("依据：").append(bestMatch.document().content()).append('\n');
        builder.append("参考来源：");
        for (int i = 0; i < results.size(); i++) {
            KnowledgeSearchResult result = results.get(i);
            builder.append(i + 1)
                .append(". ")
                .append(result.document().title())
                .append(" [score=")
                .append(result.score())
                .append(", tokens=")
                .append(result.matchedTokens())
                .append("]");
            if (i < results.size() - 1) {
                builder.append('\n');
            }
        }
        return builder.toString();
    }
}
