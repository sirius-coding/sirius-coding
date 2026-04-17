package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AgentService {

    private final RetrievalService retrievalService;

    public AgentService(KnowledgeBase knowledgeBase) {
        this.retrievalService = new RetrievalService(knowledgeBase);
    }

    public AgentAnswer answer(String question) {
        List<KnowledgeDocument> sources = retrievalService.findRelevantDocuments(question, 1);
        if (sources.isEmpty()) {
            return new AgentAnswer(
                "没有在知识库中找到与问题相关的资料，建议补充文档后再检索。",
                List.of()
            );
        }

        KnowledgeDocument bestMatch = sources.get(0);
        String summary = "基于知识库检索，最相关的资料是《%s》: %s"
            .formatted(bestMatch.title(), bestMatch.content());
        return new AgentAnswer(summary, sources);
    }
}

