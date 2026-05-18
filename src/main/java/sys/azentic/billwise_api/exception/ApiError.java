package sys.azentic.billwise_api.exception;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
@Builder
public class ApiError {
    private final int status;
    private final String error;
    private final String message;
    private final String path;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private final Instant timestamp;
    private final List<String> details;
}
