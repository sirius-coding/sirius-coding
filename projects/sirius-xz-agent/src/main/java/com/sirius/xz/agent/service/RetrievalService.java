package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class RetrievalService {

    private final KnowledgeBase knowledgeBase;

    public RetrievalService(KnowledgeBase knowledgeBase) {
        this.knowledgeBase = knowledgeBase;
    }

    public List<KnowledgeDocument> findRelevantDocuments(String question, int limit) {
        Set<String> questionTokens = tokens(question);
        return knowledgeBase.documents().stream()
            .sorted(Comparator.comparingInt((KnowledgeDocument doc) -> score(doc, questionTokens)).reversed())
            .filter(doc -> score(doc, questionTokens) > 0)
            .limit(limit)
            .collect(Collectors.toList());
    }

    int score(KnowledgeDocument document, Set<String> questionTokens) {
        Set<String> docTokens = tokens(document.searchableText());
        int overlap = 0;
        for (String token : questionTokens) {
            if (docTokens.contains(token)) {
                overlap++;
            }
        }
        return overlap;
    }

    private Set<String> tokens(String text) {
        return Arrays.stream(text.toLowerCase(Locale.ROOT).split("[^a-z0-9]+"))
            .filter(token -> !token.isBlank())
            .collect(Collectors.toCollection(LinkedHashSet::new));
    }
}

