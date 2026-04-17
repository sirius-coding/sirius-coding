package com.sirius.web.toolkit.web;

import com.sirius.web.toolkit.api.ApiResponse;
import com.sirius.web.toolkit.api.EchoResponse;
import com.sirius.web.toolkit.context.RequestContext;
import com.sirius.web.toolkit.error.BizException;
import com.sirius.web.toolkit.error.ErrorCode;

public final class ToolkitSmokeTest {

    private ToolkitSmokeTest() {
    }

    public static void main(String[] args) {
        ToolkitController controller = new ToolkitController();
        GlobalExceptionHandler handler = new GlobalExceptionHandler();

        RequestContext.setRequestId("req-123");
        ApiResponse<EchoResponse> echoResponse = controller.echo("hello");
        if (echoResponse.code() != 0) {
            throw new IllegalStateException("Echo response should be successful");
        }
        if (!"hello".equals(echoResponse.data().message())) {
            throw new IllegalStateException("Echo response should contain the original message");
        }
        if (!"req-123".equals(echoResponse.requestId())) {
            throw new IllegalStateException("Echo response should carry the request id");
        }

        try {
            controller.fail();
            throw new IllegalStateException("Fail endpoint should throw BizException");
        } catch (BizException ex) {
            var response = handler.handleBizException(ex);
            if (response.getStatusCode().value() != ErrorCode.INVALID_REQUEST.httpStatus().value()) {
                throw new IllegalStateException("Unexpected error status: " + response.getStatusCode());
            }
            if (response.getBody() == null || response.getBody().code() != ErrorCode.INVALID_REQUEST.code()) {
                throw new IllegalStateException("Unexpected error payload");
            }
        }
    }
}

