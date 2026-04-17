package com.sirius.xz.agent.service;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;

public class DeepSeekStructuredAnswerGenerator implements StructuredAnswerGenerator {

    private final ChatModel chatModel;

    public DeepSeekStructuredAnswerGenerator(ChatModel chatModel) {
        this.chatModel = chatModel;
    }

    @Override
    public String generate(String question, List<KnowledgeSearchResult> results) {
        Prompt prompt = new Prompt(
            new SystemMessage("""
                你是 sirius-xz-agent 的技术助手。
                你需要基于提供的知识库上下文回答问题。
                如果上下文不足，请明确说明缺少信息，不要编造。
                输出风格要简洁、结构化、中文优先。
                """),
            new UserMessage(buildUserPrompt(question, results))
        );

        ChatResponse response = chatModel.call(prompt);
        AssistantMessage output = response.getResult().getOutput();
        return output.getText();
    }

    private String buildUserPrompt(String question, List<KnowledgeSearchResult> results) {
        String context = results.stream()
            .map(result -> """
                - 标题: %s
                  ID: %s
                  内容: %s
                  命中词: %s
                  分数: %d
                """.formatted(
                result.document().title(),
                result.document().id(),
                result.document().content(),
                result.matchedTokens(),
                result.score()
            ))
            .collect(Collectors.joining("\n"));

        return """
            问题：%s

            知识库上下文：
            %s

            请返回：
            1. 一段直接回答
            2. 必要时列出参考来源
            3. 保持结果和上下文一致
            """.formatted(question, context);
    }
}
