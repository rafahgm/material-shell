#!/usr/bin/env bun
import { createCLI } from '@bunli/core'
import wallpaperCommand from './commands/wallpaper.js'

const cli = await createCLI({
  name: 'Material Shell',
  version: '0.1.0',
  description: 'CLI do Material Shell'
})

cli.command(wallpaperCommand)

await cli.run()