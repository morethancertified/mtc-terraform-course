document.addEventListener('DOMContentLoaded', () => {
    const questionTextElement = document.getElementById('question-text');
    const answerInput = document.getElementById('answer-input');
    const submitButton = document.getElementById('submit-button');
    const feedbackContainer = document.getElementById('feedback-container');
    const feedbackTextElement = document.getElementById('feedback-text');
    const newQuestionButton = document.getElementById('new-question-button'); // Get new button reference
    const backendUrl = 'BACKEND_PLACEHOLDER'; // Adjust if backend runs on a different port or hostname
    // Function to fetch a question from the backend
    const fetchQuestion = async () => {
        try {
            const response = await fetch(`${backendUrl}/api/question`);
            const data = await response.json();
            questionTextElement.textContent = data.question;
            answerInput.value = ''; // Clear answer input when new question is loaded
            feedbackContainer.classList.add('hidden'); // Hide feedback container
        } catch (error) {
            console.error('Error fetching question:', error);
            questionTextElement.textContent = 'Error loading question. Please check backend.';
        }
    };
    // Function to submit the answer to the backend (remains the same)
    const submitAnswer = async () => {
        const question = questionTextElement.textContent;
        const answer = answerInput.value;
        if (!answer.trim()) {
            alert('Please enter your answer.');
            return;
        }
        try {
            const response = await fetch(`${backendUrl}/api/submit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ question: question, answer: answer }),
            });
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Submission failed');
            }
            const data = await response.json();
            feedbackTextElement.textContent = data.feedback;
            feedbackContainer.classList.remove('hidden'); // Show feedback container
        } catch (error) {
            console.error('Error submitting answer:', error);
            alert(`Error submitting answer: ${error.message}`);
        }
    };
    // Event listener for submit button (remains the same)
    submitButton.addEventListener('click', submitAnswer);
    // Event listener for new question button
    newQuestionButton.addEventListener('click', fetchQuestion); // Call fetchQuestion on click
    // Fetch question on page load (remains the same)
    fetchQuestion();
});