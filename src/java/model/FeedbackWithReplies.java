package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Container used by product-detail to render a single review + all its
 * replies together. The DAO hydrates this in one pass.
 */
public class FeedbackWithReplies implements Serializable {

    private FeedbackModel feedback;
    private List<FeedbackReplyModel> replies = new ArrayList<>();

    public FeedbackModel getFeedback() { return feedback; }
    public void setFeedback(FeedbackModel feedback) { this.feedback = feedback; }

    public List<FeedbackReplyModel> getReplies() { return replies; }
    public void setReplies(List<FeedbackReplyModel> replies) { this.replies = replies; }

    public boolean isManagerAnswered() {
        if (replies == null) return false;
        for (FeedbackReplyModel r : replies) {
            if (r.isManager()) return true;
        }
        return false;
    }
}
