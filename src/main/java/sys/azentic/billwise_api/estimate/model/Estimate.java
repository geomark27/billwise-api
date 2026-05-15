package sys.azentic.billwise_api.estimate.model;

import jakarta.persistence.*;
import lombok.*;
import sys.azentic.billwise_api.user.model.User;

import java.util.UUID;

@Entity
@Table(name = "estimates")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Estimate {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String rawInput;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private InputType inputType = InputType.TEXT;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private EstimateStatus estimateStatus = EstimateStatus.DRAFT;


}
