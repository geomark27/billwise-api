package sys.azentic.billwise_api.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiError handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        List<String> details = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .toList();
        return ApiError.builder()
                .status(400)
                .error("Validation Failed")
                .message("One or more fields are invalid")
                .path(req.getRequestURI())
                .timestamp(Instant.now())
                .details(details)
                .build();
    }

    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ApiError handleBadCredentials(BadCredentialsException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(401)
                .error("Unauthorized")
                .message("Invalid email or password")
                .path(req.getRequestURI())
                .timestamp(Instant.now())
                .build();
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiError handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(400)
                .error("Bad Request")
                .message(ex.getMessage())
                .path(req.getRequestURI())
                .timestamp(Instant.now())
                .build();
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiError handleGeneric(Exception ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(500)
                .error("Internal Server Error")
                .message("An unexpected error occurred")
                .path(req.getRequestURI())
                .timestamp(Instant.now())
                .build();
    }
}
