import pino from 'pino'
import pretty from 'pino-pretty'
import { createWriteStream } from 'node:fs'

const prettyOptions = { translateTime: 'SYS:standard', ignore: 'pid,hostname' }

export const logger = pino(
  {},
  pino.multistream([
    { stream: pretty({ ...prettyOptions, colorize: true }) },
    { stream: pretty({ ...prettyOptions, colorize: false, destination: createWriteStream('.log', { flags: 'a' }) }) },
  ]),
)
