import filesize from 'filesize';
import Moment from 'moment';

export default class Image {
  public digest: string;
  public pushedAt: Moment.Moment;
  public size: number;
  public tags: string[];

  constructor(json: { [s: string]: any }) {
    this.digest = json.digest;
    this.pushedAt = Moment(json.pushed_at);
    this.size = json.size;
    this.tags = json.tags;
  }

  public get fileSize() {
    return filesize(this.size);
  }
}
