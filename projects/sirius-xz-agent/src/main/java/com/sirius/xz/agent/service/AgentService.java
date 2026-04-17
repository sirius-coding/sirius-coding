package com.sirius.xz.agent.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AgentService {

    private final RetrievalService retrievalService;
    private final StructuredAnswerGenerator answerGenerator;

    public AgentService(KnowledgeBase knowledgeBase) {
        this(new RetrievalService(knowledgeBase), new LocalStructuredAnswerGenerator());
    }

    public AgentService(RetrievalService retrievalService) {
        this(retrievalService, new LocalStructuredAnswerGenerator());
    }

    @Autowired
    public AgentService(RetrievalService retrievalService, StructuredAnswerGenerator answerGenerator) {
        this.retrievalService = retrievalService;
        this.answerGenerator = answerGenerator;
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
        String answer = answerGenerator.generate(question, results);
        List<String> matchedTokens = results.stream()
            .flatMap(result -> result.matchedTokens().stream())
            .distinct()
            .toList();
        int confidence = Math.min(100, bestMatch.score() * 10);
        return new AgentAnswer(answer, results.stream().map(KnowledgeSearchResult::document).toList(), confidence, matchedTokens);
    }
}
