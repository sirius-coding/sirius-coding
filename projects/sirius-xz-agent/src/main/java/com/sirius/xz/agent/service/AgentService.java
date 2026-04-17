package com.sirius.xz.agent.service;

import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AgentService {

    private final RetrievalService retrievalService;

    public AgentService(KnowledgeBase knowledgeBase) {
        this(new RetrievalService(knowledgeBase));
    }

    public AgentService(RetrievalService retrievalService) {
        this.retrievalService = retrievalService;
    }

    public AgentAnswer answer(String question) {
        List<KnowledgeSearchResult> results = retrievalService.search(question, 3);
        if (results.isEmpty()) {
            return new AgentAnswer(
                "没有在知识库中找到与问题相关的资料，建议补充文档后再检索。",
                List.of(),
                0,
                List.of()
            );
        }

        KnowledgeSearchResult bestMatch = results.get(0);
        String answer = composeAnswer(question, results);
        List<String> matchedTokens = results.stream()
            .flatMap(result -> result.matchedTokens().stream())
            .distinct()
            .toList();
        int confidence = Math.min(100, bestMatch.score() * 10);
        return new AgentAnswer(answer, results.stream().map(KnowledgeSearchResult::document).toList(), confidence, matchedTokens);
    }

    private String composeAnswer(String question, List<KnowledgeSearchResult> results) {
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
