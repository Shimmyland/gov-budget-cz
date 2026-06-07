export class CustomError extends Error {
  // Error atributes = name, message, stack + statusCode, isOperational?
  statusCode: number

  constructor(message: string, statusCode: number) {
    super(message)
    this.statusCode = statusCode
    //Error.captureStackTrace(this, this.constructor)
  }
}

// other custom errors: ConfigError, ValidationError, ApiError

export class MisRisHeaderError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'MisRisHeaderError'
  }
}

export class MonitorClientError extends Error {
  constructor(
    public readonly status: number | null,
    message: string,
  ) {
    super(message)
    this.name = 'MonitorClientError'
  }
}
