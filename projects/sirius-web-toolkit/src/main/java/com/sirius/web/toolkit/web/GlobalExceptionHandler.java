package com.sirius.web.toolkit.web;

import com.sirius.web.toolkit.api.ApiResponse;
import com.sirius.web.toolkit.context.RequestContext;
import com.sirius.web.toolkit.error.BizException;
import com.sirius.web.toolkit.error.ErrorCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BizException.class)
    public ResponseEntity<ApiResponse<Void>> handleBizException(BizException ex) {
        ErrorCode errorCode = ex.getErrorCode();
        return ResponseEntity.status(errorCode.httpStatus())
            .body(ApiResponse.error(errorCode.code(), ex.getMessage(), RequestContext.currentRequestId()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception ex) {
        return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.httpStatus())
            .body(ApiResponse.error(ErrorCode.INTERNAL_ERROR.code(), ex.getMessage(), RequestContext.currentRequestId()));
    }
}

