package com.sirius.web.toolkit.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.sirius.web.toolkit.WebToolkitApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(classes = WebToolkitApplication.class)
@AutoConfigureMockMvc
class ToolkitControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void echoesTheMessageAndCarriesARequestId() throws Exception {
        mockMvc.perform(get("/api/toolkit/echo")
                .param("message", "hello")
                .header("X-Request-Id", "req-123"))
            .andExpect(status().isOk())
            .andExpect(header().string("X-Request-Id", "req-123"))
            .andExpect(jsonPath("$.code").value(0))
            .andExpect(jsonPath("$.data.message").value("hello"))
            .andExpect(jsonPath("$.requestId").value("req-123"));
    }

    @Test
    void mapsBusinessExceptionsToStandardErrorResponses() throws Exception {
        mockMvc.perform(get("/api/toolkit/fail")
                .header("X-Request-Id", "req-456"))
            .andExpect(status().isBadRequest())
            .andExpect(header().string("X-Request-Id", "req-456"))
            .andExpect(jsonPath("$.code").value(400))
            .andExpect(jsonPath("$.message").value("demonstration failure"))
            .andExpect(jsonPath("$.requestId").value("req-456"));
    }
}

