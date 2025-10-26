import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }

  getIntroductionWithName(name: string): string {
    return 'Hello! My name is ' + name;
  }
}
