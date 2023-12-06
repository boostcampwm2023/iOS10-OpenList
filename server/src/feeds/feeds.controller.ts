import { Controller, Get, Param, Post, Query } from '@nestjs/common';
import { FeedsService } from './feeds.service';

@Controller('feeds')
export class FeedsController {
  constructor(private readonly feedsService: FeedsService) {}

  @Get('category')
  getAllFeedsByCategory(@Query('category') category: string) {
    return this.feedsService.findAllFeedsByCategory(category);
  }

  @Post('like/:checklistId')
  postLike(@Param('checklistId') id: number) {
    return this.feedsService.updateLikeCount(id);
  }

  @Post('download/:checklistId')
  postDownload(@Param('checklistId') id: number) {
    return this.feedsService.updateDownloadCount(id);
  }
}
