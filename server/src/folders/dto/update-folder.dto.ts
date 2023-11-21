import { PickType } from '@nestjs/mapped-types';
import { CreateFolderDto } from './create-folder.dto';

export class UpdateFolderDto extends PickType(CreateFolderDto, ['title']) {}
