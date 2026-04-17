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

    public List<KnowledgeSearchResult> search(String question, int limit) {
        Set<String> questionTokens = tokens(question);
        return knowledgeBase.documents().stream()
            .map(document -> new KnowledgeSearchResult(
                document,
                score(document, questionTokens),
                matchedTokens(document, questionTokens)
            ))
            .filter(result -> result.score() > 0)
            .sorted(Comparator
                .comparingInt(KnowledgeSearchResult::score)
                .reversed()
                .thenComparing(result -> result.document().title().toLowerCase(Locale.ROOT))
                .thenComparing(result -> result.document().id()))
            .limit(limit)
            .collect(Collectors.toList());
    }

    public List<KnowledgeDocument> findRelevantDocuments(String question, int limit) {
        return search(question, limit).stream()
            .map(KnowledgeSearchResult::document)
            .toList();
    }

    int score(KnowledgeDocument document, Set<String> questionTokens) {
        int overlap = 0;
        Set<String> titleTokens = tokens(document.title());
        Set<String> contentTokens = tokens(document.content());
        Set<String> idTokens = tokens(document.id());
        Set<String> tagTokens = document.tags().stream()
            .flatMap(tag -> tokens(tag).stream())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        for (String token : questionTokens) {
            if (titleTokens.contains(token)) {
                overlap += 5;
            }
            if (idTokens.contains(token)) {
                overlap += 3;
            }
            if (tagTokens.contains(token)) {
                overlap += 2;
            }
            if (contentTokens.contains(token)) {
                overlap += 1;
            }
        }
        return overlap;
    }

    List<String> matchedTokens(KnowledgeDocument document, Set<String> questionTokens) {
        Set<String> titleTokens = tokens(document.title());
        Set<String> contentTokens = tokens(document.content());
        Set<String> idTokens = tokens(document.id());
        Set<String> tagTokens = document.tags().stream()
            .flatMap(tag -> tokens(tag).stream())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        return questionTokens.stream()
            .filter(token ->
                titleTokens.contains(token)
                    || contentTokens.contains(token)
                    || idTokens.contains(token)
                    || tagTokens.contains(token)
            )
            .toList();
    }

    private Set<String> tokens(String text) {
        return Arrays.stream(text.toLowerCase(Locale.ROOT).split("[^a-z0-9]+"))
            .filter(token -> !token.isBlank())
            .collect(Collectors.toCollection(LinkedHashSet::new));
    }
}

