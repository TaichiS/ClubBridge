// Google Identity Services 類型定義

declare global {
  interface Window {
    google?: {
      accounts: {
        oauth2: {
          initTokenClient: (config: GoogleTokenClientConfig) => GoogleTokenClient
        }
        id: {
          initialize: (config: GoogleIdConfiguration) => void
          prompt: (momentNotification?: (moment: PromptMomentNotification) => void) => void
          renderButton: (parent: HTMLElement, options: GoogleButtonConfig) => void
        }
      }
    }
  }

  const google: {
    accounts: {
      oauth2: {
        initTokenClient: (config: GoogleTokenClientConfig) => GoogleTokenClient
      }
      id: {
        initialize: (config: GoogleIdConfiguration) => void
        prompt: (momentNotification?: (moment: PromptMomentNotification) => void) => void
        renderButton: (parent: HTMLElement, options: GoogleButtonConfig) => void
      }
    }
  }
}

interface GoogleTokenClientConfig {
  client_id: string
  scope: string
  callback: (response: GoogleTokenResponse) => void
  error_callback?: (error: GoogleErrorResponse) => void
}

interface GoogleTokenClient {
  requestAccessToken: () => void
}

interface GoogleTokenResponse {
  access_token: string
  token_type: string
  expires_in: number
  scope: string
}

interface GoogleErrorResponse {
  error: string
  error_description?: string
  error_uri?: string
}

interface GoogleIdConfiguration {
  client_id: string
  callback: (response: GoogleCredentialResponse) => void
  auto_select?: boolean
  cancel_on_tap_outside?: boolean
}

interface GoogleCredentialResponse {
  credential: string
  select_by: string
}

interface GoogleButtonConfig {
  type?: 'standard' | 'icon'
  theme?: 'outline' | 'filled_blue' | 'filled_black'
  size?: 'large' | 'medium' | 'small'
  text?: 'signin_with' | 'signup_with' | 'continue_with' | 'signin'
  shape?: 'rectangular' | 'pill' | 'circle' | 'square'
  logo_alignment?: 'left' | 'center'
  width?: string | number
  locale?: string
}

interface PromptMomentNotification {
  isDisplayMoment: () => boolean
  isDisplayed: () => boolean
  isNotDisplayed: () => boolean
  getNotDisplayedReason: () => string
  isSkippedMoment: () => boolean
  isDismissedMoment: () => boolean
}

export {};