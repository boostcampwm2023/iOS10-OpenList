import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FeedModel } from './entity/feed.entity';
import { FeedsService } from './feeds.service';

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('FeedsService', () => {
  let service: FeedsService;
  let mockFeedsRepository: MockRepository<FeedModel>;

  beforeEach(async () => {
    mockFeedsRepository = {
      findOne: jest.fn(),
      find: jest.fn(),
      save: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FeedsService,
        {
          provide: getRepositoryToken(FeedModel),
          useValue: mockFeedsRepository,
        },
      ],
    }).compile();

    service = module.get<FeedsService>(FeedsService);
  });

  it('findFeedById(feedId): 피드 ID로 피드를 찾는다', async () => {
    const feedId = 1;
    const mockFeed = { feedId, likeCount: 10, downloadCount: 5 };
    mockFeedsRepository.findOne.mockResolvedValue(mockFeed);

    const result = await service.findFeedById(feedId);

    expect(mockFeedsRepository.findOne).toHaveBeenCalledWith({
      where: { feedId },
    });
    expect(result).toEqual(mockFeed);
  });

  it('findFeedById(feedId): 존재하지 않는 피드 ID에 대한 예외 처리', async () => {
    mockFeedsRepository.findOne.mockResolvedValue(undefined);

    await expect(service.findFeedById(9999)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('findAllFeedsByCategory(mainCategory): 주어진 카테고리의 모든 피드를 찾는다', async () => {
    const mainCategory = 'Sports';
    const mockFeeds = [
      { feedId: 1, mainCategory },
      { feedId: 2, mainCategory },
    ];
    mockFeedsRepository.find.mockResolvedValue(mockFeeds);

    const result = await service.findAllFeedsByCategory(mainCategory);

    expect(mockFeedsRepository.find).toHaveBeenCalledWith({
      where: { mainCategory },
    });
    expect(result).toEqual(mockFeeds);
  });

  it('updateLikeCount(feedId): 피드의 좋아요 수를 업데이트한다', async () => {
    const feedId = 1;
    const mockFeed = { feedId, likeCount: 10, downloadCount: 5 };
    mockFeedsRepository.findOne.mockResolvedValue(mockFeed);
    mockFeedsRepository.save.mockResolvedValue({ ...mockFeed, likeCount: 11 });

    const result = await service.updateLikeCount(feedId);

    expect(mockFeedsRepository.findOne).toHaveBeenCalledWith({
      where: { feedId },
    });
    expect(mockFeedsRepository.save).toHaveBeenCalledWith({
      ...mockFeed,
      likeCount: 11,
    });
    expect(result.likeCount).toEqual(11);
  });

  it('updateDownloadCount(feedId): 피드의 다운로드 수를 업데이트한다', async () => {
    const feedId = 1;
    const mockFeed = { feedId, likeCount: 10, downloadCount: 5 };
    mockFeedsRepository.findOne.mockResolvedValue(mockFeed);
    mockFeedsRepository.save.mockResolvedValue({
      ...mockFeed,
      downloadCount: 6,
    });

    const result = await service.updateDownloadCount(feedId);

    expect(mockFeedsRepository.findOne).toHaveBeenCalledWith({
      where: { feedId },
    });
    expect(mockFeedsRepository.save).toHaveBeenCalledWith({
      ...mockFeed,
      downloadCount: 6,
    });
    expect(result.downloadCount).toEqual(6);
  });
});
