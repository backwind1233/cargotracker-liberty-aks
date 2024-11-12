package org.eclipse.pathfinder.api;

import com.azure.identity.DefaultAzureCredentialBuilder;
import dev.langchain4j.model.azure.AzureOpenAiChatModel;
import dev.langchain4j.service.AiServices;
import jakarta.enterprise.context.ApplicationScoped;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ApplicationScoped
public class ShortestPathAiImpl implements ShortestPathAi {
    private static final AzureOpenAiChatModel MODEL;
    private static final ShortestPathAi SHORTEST_PATH_AI;
    private static final Logger log = LoggerFactory.getLogger(ShortestPathAiImpl.class);

    static {
        if (StringUtils.isNotBlank(System.getenv("AZURE_OPENAI_KEY"))) {
            log.info("Using AZURE_OPENAI_KEY for authentication.");
            MODEL = AzureOpenAiChatModel.builder()
                    .apiKey(System.getenv("AZURE_OPENAI_KEY"))
                    .endpoint(System.getenv("AZURE_OPENAI_ENDPOINT"))
                    .deploymentName(System.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"))
                    .temperature(0.2)
                    .logRequestsAndResponses(true)
                    .build();
        } else {
            log.info("Using AZURE_OPENAI_CLIENT_ID and Managed Identity for authentication.");
            MODEL = AzureOpenAiChatModel.builder()
                    .tokenCredential(new DefaultAzureCredentialBuilder().managedIdentityClientId(System.getenv("AZURE_OPENAI_CLIENT_ID")).build())
                    .endpoint(System.getenv("AZURE_OPENAI_ENDPOINT"))
                    .deploymentName(System.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"))
                    .temperature(0.2)
                    .logRequestsAndResponses(true)
                    .build();
        }

        SHORTEST_PATH_AI = AiServices.builder(ShortestPathAi.class)
                .chatLanguageModel(MODEL)
                .build();
    }

    public ShortestPathAiImpl() {
        // Empty constructor
    }

    @Override
    public String chat(String location, String voyage, String carrier_movement, String from, String to) {
        return SHORTEST_PATH_AI.chat(location, voyage, carrier_movement, from, to);
    }
}
