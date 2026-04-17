package com.sirius.xz.agent.service;

import org.springframework.stereotype.Service;

@Service
public class AgentSummaryService {

    public String buildSummary(String name) {
        return """
            %s 的 AI 代理样板已启动。
            当前版本先提供稳定的 Web 骨架、清晰的服务边界和后续接入 Spring AI / Spring AI Alibaba / RAG 的结构。
            """.formatted(name);
    }
}

