document.addEventListener('turbo:load', () => {
  const form = document.getElementById('new_group_chat_message');
  const input = document.getElementById('chat_message_input');

  if (form && input) {
    input.addEventListener('keypress', (event) => {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        form.requestSubmit();
      }
    });

    form.addEventListener('turbo:submit-end', () => {
      form.reset();
      input.focus();
    });
  }
});
