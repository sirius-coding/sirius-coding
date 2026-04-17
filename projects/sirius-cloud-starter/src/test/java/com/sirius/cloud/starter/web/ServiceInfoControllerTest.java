package com.sirius.cloud.starter.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.sirius.cloud.starter.SiriusCloudStarterApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(classes = SiriusCloudStarterApplication.class)
@AutoConfigureMockMvc
class ServiceInfoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void exposesServiceInfoForHomepageAndOperations() throws Exception {
        mockMvc.perform(get("/api/service-info"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.serviceName").value("sirius-cloud-starter"))
            .andExpect(jsonPath("$.discoveryEnabled").value(false))
            .andExpect(jsonPath("$.capabilities[0]").value("OpenFeign"))
            .andExpect(jsonPath("$.applicationName").value("sirius-cloud-starter"));
    }
}

