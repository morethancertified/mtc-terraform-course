from flask import Flask, request, jsonify, Blueprint
from flask_cors import CORS
from openai import OpenAI
import os
app = Flask(__name__)
# CORS(app)  # Enable CORS for frontend to access backend
CORS(app, resources={"/api/*": {"origins": "*"}})
# Retrieve the API key from the environment
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if OPENAI_API_KEY:
    client = OpenAI(api_key=OPENAI_API_KEY)
else:
    client = None
    print("Warning: OPENAI_API_KEY environment variable not set. API calls will use default responses.")
def get_terraform_question():
    """Fetches a Terraform question from OpenAI API or returns a default message if the API key is missing."""
    if not client:
        return "I can't get the question"
    try:
        response = client.chat.completions.create(
            model="gpt-4o",  # Or your preferred model
            messages=[
                {"role": "system", "content": "You are a Terraform teacher responsible for Terraform class."},
                {"role": "user", "content": "Provide a Terraform configuration trivia question and only the question."},
            ],
        )
        question = response.choices[0].message.content
        return question
    except Exception as e:
        print(f"Error fetching question from OpenAI: {e}")
        return "Failed to generate question. Please try again later."
def get_answer_feedback(question, answer):
    """Submits question and answer to OpenAI API for feedback or returns a default message if the API key is missing."""
    if not client:
        return "I can't get feedback"
    try:
        prompt = (
            f"Question: {question}\nYour Answer: {answer}\n"
        )
        response = client.chat.completions.create(
            model="gpt-4o",  # Or your preferred model
            messages=[
                {"role": "system", "content": "You are a Terraform teacher responsible for Terraform class."},
                {"role": "user", "content": (
                    f"Provide correct/incorrect feedback for {prompt} "
                    "Provide feedback for completely incorrect answers only, otherwise, just say 'Correct'. "
                    "Correctness is extremely important. Always err on the side of correctness."
                )},
            ],
        )
        feedback = response.choices[0].message.content
        return feedback
    except Exception as e:
        print(f"Error getting feedback from OpenAI: {e}")
        return "Failed to get feedback. Please try again later."
# Create a Blueprint for API routes with the prefix /api
api_bp = Blueprint('api', __name__, url_prefix='/api')
@api_bp.route('/healthcheck', methods=['GET'])
def healthcheck():
    """Simple healthcheck endpoint to verify that the service is running."""
    return jsonify({"status": "ok"})

@api_bp.route('/question', methods=['GET'])
def question_endpoint():
    """API endpoint to get a Terraform question."""
    question_text = get_terraform_question()
    return jsonify({"question": question_text})
@api_bp.route('/submit', methods=['POST'])
def submit():
    """API endpoint to submit an answer and get feedback."""
    data = request.get_json()
    question_text = data.get('question')
    user_answer = data.get('answer')
    if not question_text or not user_answer:
        return jsonify({"error": "Question and answer are required."}), 400
    feedback_text = get_answer_feedback(question_text, user_answer)
    return jsonify({"feedback": feedback_text})
# Register the Blueprint with the Flask application
app.register_blueprint(api_bp)
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')  # Run on all interfaces for Docker