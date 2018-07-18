import filesize from 'filesize';
import Moment from 'moment';

export default class Image {
  public id: string;
  public timestamp: Moment.Moment;
  public size: number;
  public tags: string[];

  constructor(json: { [s: string]: any }) {
    this.id = json.id;
    this.timestamp = Moment(json.timestamp);
    this.size = json.size;
    this.tags = json.tags;
  }

  public get fileSize() {
    return filesize(this.size);
  }
}
