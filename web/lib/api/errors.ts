export function getErrorMessage(code: string): string {
  switch (code) {
    case 'validation_error':
      return 'Please check the form and try again.';
    case 'unauthenticated':
      return 'Your session has expired. Please log in again.';
    case 'forbidden_role':
      return "You don't have permission to do this.";
    case 'forbidden_grant':
      return "This action isn't allowed right now.";
    case 'not_found':
      return "We couldn't find that.";
    case 'conflict':
      return 'This already exists or is in an invalid state.';
    case 'expired':
      return 'This link or token has expired.';
    default:
      return 'Something went wrong. Please try again.';
  }
}