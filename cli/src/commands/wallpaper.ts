import { defineCommand, option } from '@bunli/core'
import { z } from 'zod'
import {ALLOWED_WALLPAPER_EXTENSIONS} from '../common/constants'
import path from 'path'
import { setOption } from '../common/config'

const helloCommand = defineCommand({
  name: 'wallpaper',
  description: 'Define o wallpaper do sistema',
  options: {
    file: option(
      z.string(),
      { 
        description: 'Caminho da imagem',
        short: 'f'
      }
    )
  },
  handler: async ({ flags, colors }) => {
    // Copia arquivo para o local permanente e altera o nome
    const file = Bun.file(flags.file);
    const fileExists = await file.exists();

    if(!fileExists) {
        console.log(colors.red('Arquivo não encontrado'))
        return;
    }

    const extension = path.extname(file.name!)
    if(!ALLOWED_WALLPAPER_EXTENSIONS.includes(extension)) {
        console.log(colors.red(`Extensão não permitida. Extenões aceitas: ${ALLOWED_WALLPAPER_EXTENSIONS.join(', ')}`, ))
        return;
    }

    const absolutePath = path.resolve(flags.file)
    setOption("background.wallpaperPath", absolutePath)

    console.log(colors.green("Wallpaper definido com sucesso"))
  }
})

export default helloCommand