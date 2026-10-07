export type ErrorCode = 'network' | 'server' | 'parse';

export interface ErrorInfo {
  readonly message: string;
  readonly code: ErrorCode;
}

export abstract class BaseException {
  constructor(
    readonly message: string,
    readonly code: ErrorCode,
  ) {}
}

export class NetworkException extends BaseException {
  constructor(message = 'Network failure') {
    super(message, 'network');
  }
}

export class ServerException extends BaseException {
  constructor(
    readonly status: number,
    message = `Server responded with ${status}`,
  ) {
    super(message, 'server');
  }
}

export class ParseException extends BaseException {
  constructor(message = 'Invalid response') {
    super(message, 'parse');
  }
}

export class Errors {
  constructor(readonly exceptions: readonly BaseException[]) {}
}

// Texts from EXPERIENCE.md (error table); components never build them.
const messages: Record<ErrorCode, string> = {
  network: $localize`:@@error.network:No se pudo conectar. Revisa tu conexión.`,
  server: $localize`:@@error.server:Algo salió mal. Inténtalo de nuevo.`,
  parse: $localize`:@@error.parse:No se pudo leer la respuesta. Inténtalo de nuevo.`,
};

export function toErrorInfo(errors: Errors): ErrorInfo {
  const code = errors.exceptions[0]?.code ?? 'server';
  return { code, message: messages[code] };
}
